"""Generic byte transport for the persistent REVERSE-PC XI interpreter."""
import json
from pathlib import Path
import subprocess
import tempfile
import time


class XiSession:
    def __init__(self, binary, state):
        self.stderr = tempfile.TemporaryFile()
        self.process = subprocess.Popen([str(binary), str(state)], stdin=subprocess.PIPE,
                                        stdout=subprocess.PIPE, stderr=self.stderr)

    def _request(self, command, body=None):
        payload = body.encode() if isinstance(body, str) else body
        data = (command + ('\n' if payload is None else f' {len(payload)}\n')).encode()
        started = time.perf_counter_ns()
        try:
            self.process.stdin.write(data)
            if payload is not None:
                self.process.stdin.write(payload)
            self.process.stdin.flush()
            header = self.process.stdout.readline().decode().split()
        except BrokenPipeError:
            header = []
        if len(header) != 2:
            self.stderr.seek(0)
            raise RuntimeError(self.stderr.read().decode() or 'XI session ended')
        length = int(header[1])
        if not 0 <= length <= 16*1024*1024:
            raise RuntimeError('Invalid XI response length')
        result = self.process.stdout.read(length)
        if len(result) != length:
            raise RuntimeError('Truncated XI response')
        if header[0] != 'OK':
            raise RuntimeError(result.decode())
        return result.decode(), (time.perf_counter_ns() - started)/1e6

    def execute(self, source):
        result, elapsed = self._request('EXEC', source)
        return [json.loads(row) for row in result.splitlines() if row.startswith('{')], elapsed

    def save(self, destination):
        self._request('SAVE', str(Path(destination).resolve()))

    def metrics(self):
        return json.loads(self._request('METRICS')[0])

    def close(self):
        self.process.stdin.close()
        status = self.process.wait(timeout=30)
        self.process.stdout.close()
        self.stderr.close()
        if status:
            raise RuntimeError(f'XI session exited with {status}')

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()
