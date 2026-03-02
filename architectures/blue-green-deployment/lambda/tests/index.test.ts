import { APIGatewayProxyEvent, Context } from "aws-lambda";
import { handler } from "../src";

describe("Lambda Handler", () => {
  it("returns a response", async () => {
    const event = {
      httpMethod: "GET",
      pathParameters: null,
      queryStringParameters: {},
      body: null,
    } as unknown as APIGatewayProxyEvent;

    const context = {} as unknown as Context;

    const result = await handler(event, context);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body)).toEqual({ message: "hello world" });
  });
});
