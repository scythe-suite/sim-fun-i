# -*- coding: utf-8 -*-

from argparse import ArgumentParser
from sys import argv, stderr, exit

from colorama import Fore, Style

from sf.solution import autodetect_solution, SourceNotFoundException, ExecutionException
from sf.testcases import TestCases

from sf.zipgettext import DEFAULT_GETTEXT
_ = DEFAULT_GETTEXT

def main():
    parser = ArgumentParser( prog = 'sf test' )
    parser.add_argument('--solution-dir', '-s', help = 'The directory where the solution is to be found.', default = '.')
    parser.add_argument('--cases-dir', '-c', help = 'The directory where the test cases are to be found.')
    parser.add_argument('--actual-dir', '-o', help = 'The direcotry where to write the generated actual files.', default = '.')
    parser.add_argument('--no-overwrite', '-n', help = 'Whether to overwrite the actual files, if present.', default = False, action = 'store_true')
    parser.add_argument('--verbose', '-v', help = 'Whether to give verbose output.', default = False, action = 'store_true')
    args = parser.parse_args()
    if args.cases_dir is None: args.cases_dir = args.solution_dir
    if args.actual_dir is None: args.actual_dir = args.cases_dir

    try:
        solution = autodetect_solution(args.solution_dir)
    except SourceNotFoundException:
        stderr.write(Fore.RED + _('No source file found!\n') + Style.RESET_ALL)
        exit(1)
    stderr.write(Fore.BLUE + _('Using processor: {}\n').format(solution.NAME) + Style.RESET_ALL)

    cases = TestCases(args.cases_dir)
    try:
        cases.fill(solution, 'actual')
    except ExecutionException, e:
        stderr.write(Fore.RED + _('Execution returned the following errors:\n') + Style.RESET_ALL)
        stderr.write(str(e))
        exit(1)
    stderr.write(Fore.BLUE + _('Generated actual for cases: {}\n').format(', '.join(sorted(cases.keys()))) + Style.RESET_ALL)

    written = cases.write(args.actual_dir, not args.no_overwrite)
    if args.verbose: stderr.write(_('Written files:\n\t{}\n').format(',\n\t'.join(written)))