import json
from behave import then


@then('error is "{error}"')
def check_error(context, error):
    response = context.response
    assert list(response.keys()) == ['error'], \
        'Expected an error, got {}'.format(json.dumps(response))
    assert response['error'] == error, \
        'Got wrong error message "{}"'.format(response['error'])


@then('message has "{key}: {message}"')
def check_message(context, key, message):
    response = context.response
    assert list(response.keys()) == ['message'], \
        'Expected a message, got {}'.format(json.dumps(response))
    resp_msg = response['message']
    assert key in resp_msg, \
        'No key in message with {}'.format(', '.join(resp_msg.keys()))
    assert resp_msg[key] == message, \
        'Got wrong error message "{}"'.format(resp_msg[key])


@then('status code is {code}')
def check_status_code(context, code):
    assert int(code) == context.response_code, \
        'Got unexpected HTTP code {} with response {}'.format(
            context.response_code, json.dumps(context.response))
