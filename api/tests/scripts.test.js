const fs = require("fs");
const path = require("path");

const rootDir = path.join(__dirname, "..", "..");
const scriptsDir = path.join(rootDir, "scripts");
const deployDir = path.join(rootDir, "deploy");

function readScript(name) {
  return fs.readFileSync(path.join(scriptsDir, name), "utf8");
}

describe("scripts DevOps", () => {
  test("rollback.sh est implemente", () => {
    const content = readScript("rollback.sh");

    expect(content).not.toMatch(/A compléter/);
    expect(content).toContain("smoke-test.sh");
    expect(content).toContain("--no-deps --no-build");
  });

  test("backup.sh utilise pg_dump et la retention", () => {
    const content = readScript("backup.sh");

    expect(content).not.toMatch(/A compléter/);
    expect(content).toContain("pg_dump");
    expect(content).toContain("BACKUP_RETENTION_COUNT");
    expect(content).toContain("BACKUP_RETENTION_DAYS");
  });

  test("restore-test.sh restaure dans une base temporaire", () => {
    const content = readScript("restore-test.sh");

    expect(content).not.toMatch(/A compléter/);
    expect(content).toContain("RESTORE_TEST_DB");
    expect(content).toContain("DROP DATABASE");
    expect(content).toContain("SELECT COUNT(*) FROM products");
  });

  test("deploy/versions.env definit stable et current", () => {
    const content = fs.readFileSync(path.join(deployDir, "versions.env"), "utf8");

    expect(content).toContain("STABLE_API_TAG=");
    expect(content).toContain("CURRENT_API_TAG=");
    expect(content).toContain("STABLE_FRONTEND_TAG=");
    expect(content).toContain("CURRENT_FRONTEND_TAG=");
  });
});
