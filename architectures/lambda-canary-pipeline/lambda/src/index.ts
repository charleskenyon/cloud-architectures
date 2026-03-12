import { Context, APIGatewayProxyResult, APIGatewayEvent } from "aws-lambda";

export const handler = async (
  event: APIGatewayEvent & { deploymentTest: boolean; isForceFailure: boolean },
  context: Context
): Promise<APIGatewayProxyResult> => {
  console.log(`Event: ${JSON.stringify(event, null, 2)}`);
  console.log(`Context: ${JSON.stringify(context, null, 2)}`);

  if (event.deploymentTest === true && event.isForceFailure === true) {
    throw new Error("Intentional rollback test");
  }

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "SUCCESS",
      version: process.env.AWS_LAMBDA_FUNCTION_VERSION,
    }),
  };
};
