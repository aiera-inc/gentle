import math
import logging
import wave
from datetime import timedelta

from gentle import transcription
from gentle.util import work


class MultiThreadedTranscriber:
    def __init__(self, uid, kaldi_queue, chunk_len=20, overlap_t=2, nthreads=4):
        self.uid = uid
        self.chunk_len = chunk_len
        self.overlap_t = overlap_t
        self.nthreads = nthreads

        self.kaldi_queue = kaldi_queue

    def transcribe(self, wavfile, progress_cb=None):
        wav_obj = wave.open(wavfile, 'rb')
        duration = wav_obj.getnframes() / float(wav_obj.getframerate())
        n_chunks = int(math.ceil(duration / float(self.chunk_len - self.overlap_t)))

        chunks = []

        def transcribe_chunk(idx):
            wav_obj = wave.open(wavfile, 'rb')
            start_t = idx * (self.chunk_len - self.overlap_t)
            # Seek
            wav_obj.setpos(int(start_t * wav_obj.getframerate()))
            # Read frames
            buf = wav_obj.readframes(int(self.chunk_len * wav_obj.getframerate()))

            if len(buf) < 4000:
                logging.info('Short segment - ignored %d for job %s' % (idx, self.uid))
                ret = []
            else:
                k = self.kaldi_queue.get()
                k.push_chunk(buf)
                ret = k.get_final()
                # k.reset() (no longer needed)
                self.kaldi_queue.put(k)

            chunks.append({"start": start_t, "words": ret})
            logging.info('chunk %d of %d for job %s' % (len(chunks), n_chunks, self.uid))
            if progress_cb is not None:
                progress_cb({"message": ' '.join([X['word'] for X in ret]),
                             "percent": len(chunks) / float(n_chunks)})

        try:
            work(min(n_chunks, self.nthreads), transcribe_chunk, range(n_chunks), timedelta(hours=1))
        except Exception:
            logging.exception("error transcribing job %s in worker threads", self.uid)
            raise

        chunks.sort(key=lambda x: x['start'])

        # Combine chunks
        words = []
        for c in chunks:
            chunk_start = c['start']
            chunk_end = chunk_start + self.chunk_len

            chunk_words = [transcription.Word(**wd).shift(time=chunk_start) for wd in c['words']]

            # At chunk boundary cut points the audio often contains part of a
            # word, which can get erroneously identified as one or more different
            # in-vocabulary words.  So discard one or more words near the cut points
            # (they'll be covered by the ovlerap anyway).
            #
            trim = min(0.25 * self.overlap_t, 0.5)
            if c is not chunks[0]:
                while len(chunk_words) > 1:
                    chunk_words.pop(0)
                    if chunk_words[0].end > chunk_start + trim:
                        break
            if c is not chunks[-1]:
                while len(chunk_words) > 1:
                    chunk_words.pop()
                    if chunk_words[-1].start < chunk_end - trim:
                        break

            words.extend(chunk_words)

        # Remove overlap:  Sort by time, then filter out any Word entries in
        # the list that are adjacent to another entry corresponding to the same
        # word in the audio.
        words.sort(key=lambda word: word.start)
        words.append(transcription.Word(word="__dummy__"))
        words = [words[i] for i in range(len(words) - 1) if not words[i].corresponds(words[i + 1])]

        return words, duration


if __name__ == '__main__':
    # full transcription
    import sys

    logging.getLogger().setLevel('INFO')

    import gentle
    from gentle import standard_kaldi
    from gentle import kaldi_queue

    resources = gentle.Resources()

    k_queue = kaldi_queue.build(resources, 3)
    trans = MultiThreadedTranscriber("xxx", k_queue)

    with gentle.resampled(sys.argv[1]) as filename:
        words, duration = trans.transcribe(filename)

    open(sys.argv[2], 'w').write(transcription.Transcription(words=words).to_json())