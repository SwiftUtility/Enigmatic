"""Render the completed side-by-side run as a Markdown report."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def write_report(rows, environment):
    indexed = {(r['variant'], r['task'], r['records']): r for r in rows}
    assert all(r['processes'] == environment['processes'] for r in rows)

    def row(variant, task, size=10000):
        return indexed[variant, task, size]

    def ms(variant, task, size=10000):
        return row(variant, task, size)['ns_per_op'] / 1e6

    def mib(variant, metric):
        return row(variant, 'memory')[metric] / 1048576

    def table(header, values):
        return '\n'.join(['| ' + ' | '.join(header) + ' |',
                          '| ' + ' | '.join(['---'] * len(header)) + ' |']
                         + ['| ' + ' | '.join(map(str, r)) + ' |' for r in values])

    tasks = [
        ('parse', 'JSON → tree'), ('write-sorted', 'Tree → JSON, sorted keys'),
        ('parse-patch-write-sorted', 'JSON → edit 10 IDs → JSON, sorted keys'),
        ('lookup-10', 'Read 10 IDs from a prepared tree'),
        ('patch-10', 'Edit 10 IDs in a copy of a prepared tree'),
        ('model-tree-model', 'Model → tree → model'),
    ]
    common = ['previous-foundation', 'current-foundation', 'anycodable-foundation']
    fast = ['previous-serialization', 'current-serialization', 'current-codec', 'anycodable-serialization']
    names = {
        'previous-foundation': 'Previous Enigma / JSONDecoder',
        'current-foundation': 'Current Enigma / JSONDecoder',
        'anycodable-foundation': 'AnyCodable / JSONDecoder',
        'previous-serialization': 'Previous Enigma / JSONSerialization + cast',
        'current-serialization': 'Current Enigma / JSONSerialization + cast',
        'current-codec': 'Current Enigma / Codec Data',
        'anycodable-serialization': 'AnyCodable / native objects + native writer',
    }
    old_parse = ms('previous-foundation', 'parse')
    new_parse = ms('current-foundation', 'parse')
    codec_parse = ms('current-codec', 'parse')
    parts = [
        '# Current branch vs previous Enigmatic and AnyCodable',
        f"Current: `{environment['branch']}` at `{environment['current_commit'][:7]}`. "
        f"Previous: `v3.0.0` (`{environment['previous_commit'][:7]}`), the version used in the earlier comparison. "
        'AnyCodable: **0.6.7**, pinned to `862808b`. All versions were rebuilt and rerun.',
        '## Findings',
        f'- The common Foundation decoder path is effectively unchanged: **{old_parse:.2f} → {new_parse:.2f} ms** '
        f'({(new_parse / old_parse - 1) * 100:+.2f}%). AnyCodable still takes less time on this path '
        f'(**{ms("anycodable-foundation", "parse"):.2f} ms**).\n'
        f'- The new Codec parser takes **{codec_parse:.2f} ms**: **{old_parse / codec_parse:.2f}× faster** '
        'than the previous Foundation decoder path, and '
        f'**{ms("previous-serialization", "parse") / codec_parse:.2f}× faster** than the previous '
        'JSONSerialization + cast path.\n'
        f'- Codec writing is weaker here: **{ms("current-codec", "write-sorted"):.2f} ms**, versus '
        f'**{ms("current-foundation", "write-sorted"):.2f} ms** with JSONEncoder. Both sort keys.\n'
        f'- AnyCodable wrapping native JSONSerialization objects remains faster for plain JSON: '
        f'**{ms("anycodable-serialization", "parse"):.2f} ms** to read, '
        f'**{ms("anycodable-serialization", "parse-patch-write-sorted"):.2f} ms** for read/edit/write, '
        f'and **{mib("anycodable-serialization", "rss_delta_bytes"):.2f} MiB** retained RSS growth. '
        'It does not build an Enigma tree or provide its path and merge APIs.\n'
        f'- The new parser does not reduce retained memory: Codec uses '
        f'**{mib("current-codec", "rss_delta_bytes"):.2f} MiB** RSS growth, versus '
        f'**{mib("current-foundation", "rss_delta_bytes"):.2f} MiB** with Foundation decoding.\n'
        '- The direct Enigma model/tree bridge remains useful. AnyCodable needs an intermediate JSON route; '
        'using its faster native-object route narrows the difference substantially. Both routes are shown below.',
        '## Same Foundation JSONDecoder backend',
        '10,000 records; **1,697,836 UTF-8 bytes**. Times are milliseconds per operation; lower is better. '
        'All JSON writers in the wire-output tasks sort keys.',
        table(['Operation', 'Previous Enigma', 'Current Enigma', 'AnyCodable'],
              [[label] + [f'{ms(v, task):.4f}' for v in common] for task, label in tasks]),
        'Process median absolute deviations for JSON reading: '
        + ', '.join(f'{names[v]} **{row(v, "parse")["ns_per_op_mad_percent"]:.2f}%**' for v in common) + '.',
        'The model/tree row measures direct Enigma encoding and decoding in memory. AnyCodable uses '
        'model → JSONEncoder → JSONDecoder(AnyCodable) → JSONEncoder → JSONDecoder(model), since it has '
        'no generic in-memory model/tree coder. Intermediate JSON in this row is not sorted.',
        '## Other supported API paths',
        table(['Operation', 'Previous JSONSerialization + cast', 'Current JSONSerialization + cast',
               'Current Codec Data', 'AnyCodable native objects'],
              [[label] + [f'{ms(v, task):.4f}' for v in fast] for task, label in tasks]),
        'The dedicated Codec parser is **unavailable in previous Enigmatic and AnyCodable** (—). '
        'Its results are separate from the common Codable decoder comparison. The Codec Data path includes '
        'Data/String/UTF-8 conversions inside timed operations.',
        'Enigma’s JSONSerialization routes construct Enigma nodes and use JSONEncoder to write. '
        'The AnyCodable native route wraps JSONSerialization objects and writes them with JSONSerialization. '
        'Its model roundtrip uses those same native readers/writers, without sorted intermediate JSON. '
        'These are valid end-to-end alternatives, with different implementations and API guarantees.',
        '## Retained memory',
        '16 independent decodes of the same 1,697,836-byte Data, held alive in each fresh process. '
        'RSS growth and live malloc heap growth are measured against a warmed baseline, **before** '
        'validation. Values are MiB. Peak RSS is a whole-process measurement captured before validation; '
        'it is not the same metric as retained RSS growth.',
        table(['Path', 'Retained RSS growth', 'Live heap growth', 'Whole-process peak RSS'],
              [[names[v], f'{mib(v, "rss_delta_bytes"):.2f}', f'{mib(v, "heap_delta_bytes"):.2f}',
                f'{mib(v, "peak_rss_bytes"):.2f}'] for v in common + fast]),
        'RSS also includes allocator pages and runtime metadata; it is not an exact object-size count. '
        'No manual sharing of a decoded tree is used. Foundation may legitimately share string storage '
        'backed by the common input Data.',
        '## Smaller input',
        '100 records; **16,411 UTF-8 bytes**. Times are milliseconds.',
        table(['Path', 'Read JSON', 'Write sorted JSON', 'Read/edit/write sorted JSON'],
              [[names[v]] + [f'{ms(v, t, 100):.4f}' for t in ['parse', 'write-sorted', 'parse-patch-write-sorted']]
               for v in common + fast]),
        '## Fairness, correctness and reproducibility',
        'The original fixture bytes were recovered; the generator checks their original SHA-256 hashes. '
        'The original comparison source was missing, so this driver was rebuilt around the same tree '
        'workloads and model. Compare columns within this fresh run rather than combining them with old timings.',
        f"Each result is the median of **{environment['processes']} fresh process medians**. Each timing process "
        f"uses **{environment['batches_per_process']} batches**, rotating operation order. Fast operations are "
        'batched toward 10 ms, capped at 1,000 iterations. Warm-up, setup and correctness checks are outside '
        'the clock; operation cleanup and autoreleasepool draining are inside. Variants rotate between rounds, '
        'and no benchmark processes run concurrently. All measured thermal states were nominal.',
        'Every path verifies the complete model, JSON field values, Unicode, nulls, edits to 10 IDs, and '
        'preservation of the original copy. The memory run validates all 16 results after its snapshots. '
        'The fixture uses valid JSON and small finite numbers. These checks do not establish equivalent '
        'behavior for Date/Data, 128-bit numbers, invalid inputs, defaults, merge policies or arbitrary paths. '
        'Enigmatic’s extra APIs do not by themselves explain away the measured speed or memory gaps.',
        'AnyCodable 0.6.7 needs the native writer for its native-object route: wrapping JSONSerialization '
        'objects and then using JSONEncoder changes numeric 0/1 into booleans on this platform. '
        'The chosen native writer passes the same correctness checks. See [probe.json](probe.json).',
        f"Machine: {environment['hardware']['chip_type']}, {environment['hardware']['number_processors']}, "
        f"{environment['hardware']['physical_memory']}; {environment['platform']}. "
        f"Compiler: `{environment['swift'].splitlines()[0]}`. Build flags: "
        '`-O -whole-module-optimization`, arm64 macOS 14 target; Swift language mode 6 for Enigmatic '
        'and the shared harness, mode 5 for AnyCodable, matching its manifest. Libraries are compiled '
        'from isolated source snapshots. The current uncommitted Package.swift change is recorded in metadata; '
        'no package manifest is edited by the harness.',
        'Run from the repository root:\n\n'
        '```sh\npython3 Benchmarks/BranchComparison/run.py\n```\n\n'
        'The script uses the existing AnyCodable 0.6.7 checkout under '
        '`Benchmarks/Comparison/.build/checkouts/AnyCodable`; pass `--anycodable /path/to/AnyCodable` '
        'to use another checkout of that exact revision. It requires macOS arm64 and the installed Swift toolchain.',
        '[Environment and source hashes](environment.json) · [All timing samples and memory snapshots](raw.jsonl) · '
        '[Summary CSV](summary.csv) · [Summary JSON](summary.json) · '
        '[Swift harness](../benchmark.swift) · [Runner](../run.py)',
    ]
    (HERE / 'Results/REPORT.md').write_text('\n\n'.join(parts) + '\n')


if __name__ == '__main__':
    folder = HERE / 'Results'
    write_report(json.loads((folder / 'summary.json').read_text()),
                 json.loads((folder / 'environment.json').read_text()))
