jest.mock("../src/db");

const request = require("supertest");
const db = require("../src/db");
const app = require("../src/app");

const sampleProducts = [
  {
    id: 1,
    name: "Clavier compact",
    description: "Clavier mecanique compact pour developpeur.",
    price_cents: 5990
  }
];

beforeEach(() => {
  jest.clearAllMocks();
});

test("GET /products retourne la liste des produits", async () => {
  db.query.mockResolvedValue({ rows: sampleProducts });

  const response = await request(app).get("/products");

  expect(response.status).toBe(200);
  expect(response.body.source).toBe("database");
  expect(response.body.data).toEqual(sampleProducts);
  expect(db.query).toHaveBeenCalledWith(
    "SELECT id, name, description, price_cents FROM products ORDER BY id"
  );
});

test("GET /products retourne 500 en cas d'erreur base", async () => {
  db.query.mockRejectedValue(new Error("database unavailable"));

  const response = await request(app).get("/products");

  expect(response.status).toBe(500);
  expect(response.body.error).toBe("Internal server error");
});
