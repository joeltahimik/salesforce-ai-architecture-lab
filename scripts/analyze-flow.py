#!/usr/bin/env python3

from pathlib import Path
from collections import defaultdict
import argparse
import sys
import xml.etree.ElementTree as ET

NS = "http://soap.sforce.com/2006/04/metadata"
q = lambda tag: f"{{{NS}}}{tag}"

ELEMENT_TYPES = [
    "actionCalls",
    "assignments",
    "collectionProcessors",
    "decisions",
    "loops",
    "recordCreates",
    "recordDeletes",
    "recordLookups",
    "recordUpdates",
    "screens",
    "subflows",
]


def text(parent, tag, default=""):
    node = parent.find(q(tag))
    return node.text if node is not None and node.text else default


def main():
    parser = argparse.ArgumentParser(
        description="Analyze the structure and connectivity of Salesforce Flow metadata."
    )
    parser.add_argument(
        "flow",
        type=Path,
        help="Path to a .flow-meta.xml file",
    )
    args = parser.parse_args()

    path = args.flow

    if not path.is_file():
        print(f"ERROR: Flow file not found: {path}", file=sys.stderr)
        return 2

    try:
        tree = ET.parse(path)
    except ET.ParseError as exc:
        print(f"ERROR: Invalid XML: {exc}", file=sys.stderr)
        return 2

    root = tree.getroot()

    label = text(root, "label", path.stem)
    status = text(root, "status", "Unknown")

    canvas_mode = "Not specified"
    for item in root.findall(q("processMetadataValues")):
        if text(item, "name") == "CanvasMode":
            value = item.find(q("value"))
            if value is not None:
                canvas_mode = text(value, "stringValue", "Not specified")

    elements = {}

    for element_type in ELEMENT_TYPES:
        for element in root.findall(q(element_type)):
            name = text(element, "name")
            if name:
                elements[name] = {
                    "type": element_type,
                    "node": element,
                }

    incoming = defaultdict(list)
    broken_targets = []

    for source_name, info in elements.items():
        node = info["node"]

        for connector_tag in ("connector", "defaultConnector"):
            for connector in node.iter(q(connector_tag)):
                target = text(connector, "targetReference")

                if not target:
                    continue

                incoming[target].append(source_name)

                if target not in elements:
                    broken_targets.append((source_name, target))

    start = root.find(q("start"))
    start_target = None

    if start is not None:
        connector = start.find(q("connector"))
        if connector is not None:
            start_target = text(connector, "targetReference")

            if start_target:
                incoming[start_target].append("START")

                if start_target not in elements:
                    broken_targets.append(("START", start_target))

    orphans = [
        name
        for name in elements
        if not incoming.get(name)
    ]

    print()
    print("SALESFORCE FLOW ANALYZER")
    print("=" * 76)
    print(f"Flow:        {label}")
    print(f"File:        {path}")
    print(f"Status:      {status}")
    print(f"Canvas Mode: {canvas_mode}")
    print(f"Elements:    {len(elements)}")
    print()

    print("CONNECTION REPORT")
    print("=" * 76)

    for name in sorted(elements):
        sources = sorted(set(incoming.get(name, [])))

        state = (
            "CONNECTED"
            if sources
            else "NO INCOMING CONNECTION"
        )

        print(
            f"{state:24} "
            f"{elements[name]['type']:20} "
            f"{name}"
        )

        if sources:
            print(f"{'':24} from: {', '.join(sources)}")

    print()
    print("STRUCTURAL CHECKS")
    print("=" * 76)

    if canvas_mode == "AUTO_LAYOUT_CANVAS":
        print("PASS  Auto-Layout enabled")
    else:
        print(f"INFO  Canvas mode: {canvas_mode}")

    if not orphans:
        print("PASS  No orphaned Flow elements")
    else:
        print(f"FAIL  {len(orphans)} orphaned element(s)")
        for name in sorted(orphans):
            print(f"      {elements[name]['type']}: {name}")

    if not broken_targets:
        print("PASS  All connector targets exist")
    else:
        print(f"FAIL  {len(broken_targets)} broken connector target(s)")
        for source, target in broken_targets:
            print(f"      {source} -> {target}")

    print()
    print("RESULT")
    print("=" * 76)

    if orphans or broken_targets:
        print("FAIL  Structural issues detected.")
        return 1

    print("PASS  Flow graph is structurally connected.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
