import argparse
import logging
import os
import shutil
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

from tqdm.contrib.concurrent import process_map


def batch(iterable, n=1):
    l = len(iterable)
    for ndx in range(0, l, n):
        yield iterable[ndx : min(ndx + n, l)]


def main():
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", type=str, help="directory containing files to process")
    parser.add_argument("output_dir", type=str, help="directory to write processed files to")
    parser.add_argument("--batch_size", type=int, default=8)
    parser.add_argument("--max_workers", type=int, default=os.cpu_count() - 4)
    parser.add_argument("--ignore_errors", action="store_true", help="ignore errors")
    args = parser.parse_args()

    input_dir = Path(args.input_dir)
    input_files = input_dir.rglob("*")
    input_files = set(file.name for file in input_files)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(exist_ok=True)
    output_files = list(output_dir.rglob("*"))
    output_dotless = set(file.name.split('.')[0] for file in output_files)
    logging.info(f"Found {len(input_files)} input files")
    logging.info(f"Found {len(output_dotless)} output files")

    input_files = [file for file in input_files if file.split('.')[0] not in output_dotless]

    logging.info(f"Processing {len(input_files)} files")

    input_files = sorted(input_files, key=lambda file: (input_dir / file).stat().st_size)

    input_files_batches = list(batch(list(input_files), args.batch_size))
    process_map(
        run_batch,
        input_files_batches,
        [input_dir] * len(input_files_batches),
        [output_dir] * len(input_files_batches),
        [args.ignore_errors] * len(input_files_batches),
        max_workers=args.max_workers,
        chunksize=1,
    )


def run_batch(input_files_batch, input_dir, output_dir, ignore_errors):
    with TemporaryDirectory() as input_temp_dir, TemporaryDirectory() as output_temp_dir:
        input_temp_dir = Path(input_temp_dir)
        output_temp_dir = Path(output_temp_dir)
        for file in input_files_batch:
            logging.info(f"cp {input_dir / file} {input_temp_dir}")
            shutil.copy(input_dir / file, input_temp_dir)

        commands = [
            f"java -Xmx5G -Xms5G -jar tmVar.jar {str(input_temp_dir)} {str(output_temp_dir)}"
        ]

        for command in commands:
            try:
                logging.info(command)
                subprocess.run([command], check=True, shell=True)
            except subprocess.CalledProcessError as e:
                logging.exception(f"Error running command: {command}")
                if "returned non-zero exit status 137" in str(e):
                    logging.error("Process killed due to memory limit")
                    return
                elif ignore_errors:
                    logging.error("Ignoring error")
                else:
                    raise e

        output_paths = list(output_temp_dir.rglob("*"))
        for output_path in output_paths:
            logging.info(f"cp {output_path} {output_dir}")
            shutil.copy(output_path, output_dir)


if __name__ == "__main__":
    main()
