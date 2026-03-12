import { APIGatewayEvent, Context } from "aws-lambda";
import { handler } from "../src";

process.env.AWS_LAMBDA_FUNCTION_VERSION = "1";

describe("Lambda Handler", () => {
  it("returns a response", async () => {
    const event = {
      httpMethod: "GET",
      pathParameters: null,
      queryStringParameters: {},
      body: null,
      deploymentTest: false,
      isForceFailure: false,
    } as APIGatewayEvent & { deploymentTest: boolean; isForceFailure: boolean };
    const context = {} as unknown as Context;

    const result = await handler(event, context);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body)).toEqual({
      message: "SUCCESS",
      version: "1",
    });
  });
});
