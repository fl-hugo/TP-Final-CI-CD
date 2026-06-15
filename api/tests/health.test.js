jest.mock("../src/db");

const request = require("supertest");
const db = require("../src/db");
const app = require("../src/app");

beforeEach(() => {
  jest.clearAllMocks();
});

test("GET /health retourne ok quand la base repond", async () => {
  db.query.mockResolvedValue({ rows: [{ "?column?": 1 }] });

  const response = await request(app).get("/health");

  expect(response.status).toBe(200);
  expect(response.body.status).toBe("ok");
  expect(response.body.service).toBe("shoplite-api");
  expect(response.body.checks.api).toBe("ok");
  expect(response.body.checks.database).toBe("ok");
  expect(response.body.timestamp).toBeDefined();
});

test("GET /health retourne 503 quand la base est indisponible", async () => {
  db.query.mockRejectedValue(new Error("connection refused"));

  const response = await request(app).get("/health");

  expect(response.status).toBe(503);
  expect(response.body.status).toBe("error");
  expect(response.body.checks.database).toBe("error");
});
