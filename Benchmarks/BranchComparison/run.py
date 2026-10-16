#!/usr/bin/env python3
"""Rerun the original fixtures against source snapshots; requires macOS/Swift 6.4.

python3 Benchmarks/BranchComparison/run.py [--processes 5] [--samples 9]
Uses the cached AnyCodable 0.6.7 checkout by default; override with --anycodable.
Builds run serially, followed by rotating serial timing and memory processes.
"""
import argparse
import csv
import hashlib
import io
import json
import platform
from pathlib import Path
import shutil
import statistics
import subprocess
import tarfile
from datetime import datetime
from report import write_report

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BUILD = HERE / '.build'
OUT = HERE / 'Results'
PREVIOUS = 'b28cb626f9af52ca8ad8754f1bb80670bff73741'
ANY_REV = '862808b2070cd908cb04f9aafe7de83d35f81b05'
VARIANTS = [
    ('previous-foundation', 'previous', 'foundation'),
    ('current-foundation', 'current', 'foundation'),
    ('anycodable-foundation', 'anycodable', 'foundation'),
    ('current-codec', 'current', 'codec'),
    ('previous-serialization', 'previous', 'serialization'),
    ('current-serialization', 'current', 'serialization'),
    ('anycodable-serialization', 'anycodable', 'serialization'),
]


def command(args, **kwargs):
    return subprocess.check_output([str(x) for x in args], text=True, **kwargs).strip()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def source_hash(root):
    files = sorted((root / 'Sources').rglob('*.swift'))
    h = hashlib.sha256()
    for p in files:
        h.update(str(p.relative_to(root)).encode() + b'\0' + p.read_bytes() + b'\0')
    return h.hexdigest()


def fixture(count):
    note = 'hello' + chr(92) + 'world' + chr(10) + 'line'
    records = [dict(
        id=i, name=f'User {i} — café 東京', active=i % 3 != 0, score=i * .125,
        tags=['swift', 'codable', f'group-{i % 17}'],
        meta=dict(city='Vienna', rank=i % 97, note=note if i % 2 else None),
    ) for i in range(count)]
    return json.dumps(dict(records=records, version=1), ensure_ascii=False, separators=(',', ':')).encode()


def build(label, root, module, defines, language):
    target = BUILD / label
    target.mkdir(parents=True, exist_ok=True)
    flags = ['-O', '-whole-module-optimization',
             '-target', 'arm64-apple-macosx14.0', '-module-cache-path', str(BUILD / 'modules')]
    sources = sorted((root / 'Sources' / module).rglob('*.swift'))
    with (OUT / f'build-{label}.log').open('w') as log:
        subprocess.run(['xcrun', 'swiftc', *flags, '-swift-version', language, '-parse-as-library', '-emit-library',
                        '-emit-module', '-module-name', module, '-emit-module-path',
                        str(target / f'{module}.swiftmodule'), '-o', str(target / f'lib{module}.dylib'),
                        *map(str, sources)], stdout=log, stderr=log, check=True)
        subprocess.run(['xcrun', 'swiftc', *flags, '-swift-version', '6', '-parse-as-library', *defines,
                        '-I', str(target), '-L', str(target), f'-l{module}',
                        '-o', str(target / 'benchmark'), str(HERE / 'benchmark.swift')],
                       stdout=log, stderr=log, check=True)
    print(f'Built {label}', flush=True)


def summarize(records):
    rows = []
    keys = sorted(set((r['variant'], r['task'], r['records']) for r in records))
    for variant, task, size in keys:
        group = [r for r in records if (r['variant'], r['task'], r['records']) == (variant, task, size)]
        row = dict(variant=variant, task=task, records=size, processes=len(group))
        metrics = ['rss_delta_bytes', 'heap_delta_bytes', 'rss_held_bytes', 'peak_rss_bytes'] if task == 'memory' else ['ns_per_op', 'cpu_ns_per_op']
        for metric in metrics:
            values = [r[metric] for r in group]
            median = statistics.median(values)
            row[metric] = median
            row[metric + '_mad_percent'] = statistics.median(abs(x - median) for x in values) / median * 100 if median else 0
            row[metric + '_min'] = min(values)
            row[metric + '_max'] = max(values)
        rows.append(row)
    (OUT / 'summary.json').write_text(json.dumps(rows, indent=2) + '\n')
    fields = list(dict.fromkeys(k for row in rows for k in row))
    with (OUT / 'summary.csv').open('w') as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    return rows


def probe():
    args = ['xcrun', 'swiftc', '-O', '-swift-version', '6', '-parse-as-library',
            '-target', 'arm64-apple-macosx14.0', '-module-cache-path', str(BUILD / 'modules')]
    for label, module in [('current', 'Enigmatic'), ('anycodable', 'AnyCodable')]:
        args += ['-I', str(BUILD / label), '-L', str(BUILD / label), f'-l{module}']
    args += ['-o', str(BUILD / 'probe'), str(HERE / 'probe.swift')]
    with (OUT / 'build-probe.log').open('w') as log:
        subprocess.run(args, stdout=log, stderr=log, check=True)
    result = command([BUILD / 'probe'])
    (OUT / 'probe.json').write_text(result + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--processes', type=int, default=5)
    parser.add_argument('--samples', type=int, default=9)
    parser.add_argument('--anycodable', type=Path, default=ROOT / 'Benchmarks/Comparison/.build/checkouts/AnyCodable')
    args = parser.parse_args()
    assert args.processes > 0 and args.samples > 0 and args.samples % 2 == 1
    BUILD.mkdir(parents=True, exist_ok=True)
    OUT.mkdir(parents=True, exist_ok=True)
    current = BUILD / 'current-source'
    previous = BUILD / 'previous-source'
    if current.exists():
        shutil.rmtree(current)
    current.mkdir(exist_ok=True)
    shutil.copytree(ROOT / 'Sources', current / 'Sources', dirs_exist_ok=True)
    archive = subprocess.check_output(['git', '-C', str(ROOT), 'archive', PREVIOUS, 'Sources'])
    previous.mkdir(exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        tar.extractall(previous)
    assert command(['git', '-C', args.anycodable, 'rev-parse', 'HEAD']) == ANY_REV
    assert not command(['git', '-C', args.anycodable, 'status', '--porcelain', '--untracked-files=no'])
    hashes = {n: source_hash(p) for n, p in [('current', current), ('previous', previous), ('anycodable', args.anycodable)]}
    hardware = json.loads(command(['system_profiler', 'SPHardwareDataType', '-json']))['SPHardwareDataType'][0]
    metadata = dict(
        date=datetime.now().astimezone().isoformat(), platform=platform.platform(),
        swift=command(['xcrun', 'swiftc', '--version']),
        hardware={k: hardware[k] for k in ['chip_type', 'machine_model', 'number_processors', 'physical_memory']},
        branch=command(['git', '-C', ROOT, 'branch', '--show-current']),
        current_commit=command(['git', '-C', ROOT, 'rev-parse', 'HEAD']), previous_commit=PREVIOUS,
        current_source_sha256=hashes['current'], previous_source_sha256=hashes['previous'],
        anycodable_version='0.6.7', anycodable_revision=ANY_REV, anycodable_source_sha256=hashes['anycodable'],
        current_working_diff=command(['git', '-C', ROOT, 'diff', '--', 'Package.swift', 'Sources']),
        harness_sha256=digest((HERE / 'benchmark.swift').read_bytes()),
        processes=args.processes, batches_per_process=args.samples, copies=16,
        build_flags='-O -whole-module-optimization; Enigmatic/benchmark Swift 6; AnyCodable Swift 5',
        fixtures={},
    )
    expected = {100: 'c753b49fb0bc6592c56692f62b3c8b50da26871bfd0832c2c6d1c84118e1e009',
                10000: 'dfa3d5e97d9979bfc177743a22a3fc2b51cf4a908b44ba802fe9893b5d905a60'}
    for size in [100, 10000]:
        data = fixture(size)
        assert digest(data) == expected[size], 'Fixture differs from the historical benchmark'
        (BUILD / f'tree-{size}.json').write_bytes(data)
        metadata['fixtures'][size] = dict(bytes=len(data), sha256=digest(data))
    (OUT / 'environment.json').write_text(json.dumps(metadata, indent=2) + '\n')
    build('previous', previous, 'Enigmatic', ['-D', 'ENIGMA'], '6')
    build('current', current, 'Enigmatic', ['-D', 'ENIGMA', '-D', 'HAS_JSON_CODEC'], '6')
    build('anycodable', args.anycodable, 'AnyCodable', [], '5')
    probe()
    records = []
    with (OUT / 'raw.jsonl').open('w') as stream:
        for mode in ['timing', 'memory']:
            for round_index in range(args.processes):
                ordered = VARIANTS[round_index % len(VARIANTS):] + VARIANTS[:round_index % len(VARIANTS)]
                for size in ([100, 10000] if mode == 'timing' else [10000]):
                    for variant, binary, backend in ordered:
                        output = command([BUILD / binary / 'benchmark', backend, BUILD / f'tree-{size}.json',
                                          mode, args.samples if mode == 'timing' else 16])
                        for line in output.splitlines():
                            record = json.loads(line)
                            record.update(variant=variant, round=round_index + 1, records=size)
                            states = record.get('thermal_states', [record.get('thermal_state')])
                            assert all(state == 0 for state in states), f'Thermal pressure: {record}'
                            records.append(record)
                            stream.write(json.dumps(record) + '\n')
                        stream.flush()
                print(f'{mode} round {round_index + 1}/{args.processes} complete', flush=True)
    write_report(summarize(records), metadata)
    print(f'Saved {len(records)} observations to {OUT}', flush=True)


if __name__ == '__main__':
    main()
