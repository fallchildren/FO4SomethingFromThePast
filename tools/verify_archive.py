"""Verify the release GNRL archive contains exactly the compiled quest script."""
import sys
import tempfile
from pathlib import Path
from fo4tools import ba2


def verify(archive, script):
    names = ba2.list_names(archive)
    if names != ['Scripts/fcNCR_HandMeDown.pex']:
        raise ValueError(f'Unexpected archive contents: {names}')
    with tempfile.TemporaryDirectory() as tmp:
        ba2.extract_all(archive, tmp)
        extracted = Path(tmp) / names[0]
        if extracted.read_bytes() != Path(script).read_bytes():
            raise ValueError('Archived script differs from compiled PEX')
    print('Verified archive: exactly one PEX, byte-identical after extraction')


if __name__ == '__main__':
    verify(*sys.argv[1:])
