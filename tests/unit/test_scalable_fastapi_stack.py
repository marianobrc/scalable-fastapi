import aws_cdk as core
import aws_cdk.assertions as assertions

from scalable_fastapi.scalable_fastapi_stack import ScalableFastapiStack

# example tests. To run these tests, uncomment this file along with the example
# resource in scalable_fastapi/scalable_fastapi_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = ScalableFastapiStack(app, "scalable-fastapi")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
