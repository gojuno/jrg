# Custom formatter for Behave
import re
from behave.formatter.ansi_escapes import escapes
from behave.formatter.base import Formatter
from behave.model_core import Status


class BareFormatter(Formatter):
    name = 'bare'
    description = 'Prints only feature / scenario names and errors'

    def __init__(self, stream_opener, config, **kwargs):
        super().__init__(stream_opener, config)
        self.stream = self.open()
        self.print_skipped = False
        self.colored = config.color
        if hasattr(self.stream, 'isatty'):
            self.colored = self.colored and self.stream.isatty()
        self.current_scenario = None
        self.had_scenarios = False

    def write(self, indent, text, status=None):
        ind = ' ' * indent
        if status is None or not self.colored:
            self.stream.write(ind + text + '\n')
        else:
            self.stream.write(ind + escapes[status] + text +
                              escapes['reset'] + '\n')

    def feature(self, feature):
        self.write(0, '{}:'.format(feature.name))
        self.had_scenarios = False

    def print_scenario(self, msg=None):
        if self.current_scenario:
            if self.print_skipped or self.scenario_status != Status.skipped:
                self.write(2, '* {}{}'.format(self.current_scenario.name, msg or ''),
                           self.scenario_status.name)
            self.current_scenario = None

    def scenario(self, scenario):
        self.print_scenario()
        self.current_scenario = scenario
        self.scenario_status = Status.skipped
        if self.print_skipped:
            self.had_scenarios = True

    def result(self, step):
        self.scenario_status = step.status
        self.had_scenarios = True
        if step.error_message:
            self.print_scenario(': {} "{}"'.format(step.status.name, step.name))
            for line in step.error_message.split('\n'):
                line = re.sub(r'^.*Assertion Failed: ', '', line)
                self.write(6, line)

    def eof(self):
        self.print_scenario()
        if self.had_scenarios:
            self.stream.write('\n')
        self.stream.flush()
