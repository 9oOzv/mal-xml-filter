#!/usr/bin/env python3
import argparse
from defusedxml import ElementTree
from defusedxml.ElementTree import parse
#from xml.etree import ElementTree
from xml.etree.ElementTree import Element
from pathlib import Path

parser = argparse.ArgumentParser(description='Filter animelist xml export')
parser.add_argument(
    '-p',
    '--planned',
    action='store_true',
    help='Include planned'
)
parser.add_argument(
    '-w',
    '--watching',
    action='store_true',
    help='Include watching'
)
parser.add_argument(
    '-c',
    '--completed',
    action='store_true',
    help='Include completed'
)
parser.add_argument(
    '-d',
    '--dropped',
    action='store_true',
    help='Include dropped'
)
parser.add_argument(
    '-H',
    '--held',
    action='store_true',
    help='Include on-hold'
)
parser.add_argument(
    'input',
    type=str,
    help='Input xml'
)
parser.add_argument(
    'output',
    type=str,
    help='Input xml'
)

args = parser.parse_args()


status_planned = 'Plan to Watch'
status_completed = 'Completed'
status_watching = 'Watching'
status_dropped = 'Dropped'
status_held = 'On-Hold'




def debug(text: str):
    print(text)
    

class MALFilter:
    
    def _remove_action(self):
        debug(r'{:15} {}'.format(self.current_series_title, 'REMOVE'))
        self.root.remove(self.current_anime_element)

    def _no_action(self):
        debug(r'{:15} {}'.format(self.current_series_title, 'KEEP'))

    def __init__(self, options):
        no_action = self._no_action
        remove_action = self._remove_action
        print("planned: {}", options.planned)
        print("watching: {}", options.planned)
        print("completed: {}", options.planned)
        print("dropped: {}", options.planned)
        print("held: {}", options.planned)
        self.planned_action = no_action if options.planned else remove_action
        self.watching_action = no_action if options.watching else remove_action
        self.completed_action = no_action if options.completed else remove_action
        self.dropped_action = no_action if options.dropped else remove_action
        self.held_action = no_action if options.held else remove_action

    def load(self, xml_file: Path):
        with open(xml_file, 'r') as f:
            self.element_tree = parse(f)
            self.root = self.element_tree.getroot()

    def save(self, xml_file: Path):
        with open(xml_file, 'wb') as f:
            self.element_tree.write(f, encoding="utf-8")
        
    def parse_anime_element(self, anime_element: Element):
        self.current_series_title = None
        self.current_my_status = None
        self.current_anime_element = anime_element
        for e in anime_element:
            if e.tag == 'series_title':
                self.current_series_title = e.text
            if e.tag == 'my_status':
                self.current_my_status = e.text

    def filter(self):
        for anime_element in self.root.findall('anime'):
            self.parse_anime_element(anime_element)
            status = self.current_my_status
            if status == status_planned:
                self.planned_action()
            elif status == status_watching:
                self.watching_action()
            elif status == status_completed:
                self.completed_action()
            elif status == status_dropped:
                self.dropped_action()
            elif status == status_held:
                self.held_action()
            else:
                debug(r'unknown status: {}', status)


f= MALFilter(args)
f.load(Path(args.input))
f.filter()
f.save(Path(args.output))
