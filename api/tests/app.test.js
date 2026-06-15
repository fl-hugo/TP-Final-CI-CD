const request = require("supertest");
const app = require("../src/app");

test("GET / retourne le nom de l'API", async () => {
  const response = await request(app).get("/");

  expect(response.status).toBe(200);
  expect(response.body.name).toBe("ShopLite API");
  expect(response.body.version).toBe("0.1.0");
  expect(response.body.endpoints).toEqual(["/health", "/products"]);
});

test("GET /unknown retourne 404", async () => {
  const response = await request(app).get("/unknown");

  expect(response.status).toBe(404);
  expect(response.body.error).toBe("Route not found");
});
