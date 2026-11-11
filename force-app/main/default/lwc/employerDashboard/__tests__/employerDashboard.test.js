import { createElement } from "lwc";
import EmployerDashboard from "c/employerDashboard";

describe("c-employer-dashboard", () => {
  afterEach(() => {
    document.body.replaceChildren();
  });

  it("labels the dashboard as a demonstration and shows both record sections", () => {
    const dashboard = createElement("c-employer-dashboard", {
      is: EmployerDashboard
    });
    document.body.appendChild(dashboard);

    const root = dashboard.shadowRoot;
    expect(root.querySelector(".demo-note").textContent).toContain(
      "Demonstration data"
    );
    expect(
      [...root.querySelectorAll("h3")].map((heading) =>
        heading.textContent.trim()
      )
    ).toEqual(["My Workforce", "Employment Change Requests"]);
    expect(
      [...root.querySelectorAll(".records")].map((list) => list.children.length)
    ).toEqual([4, 3]);
  });

  it("shows counts consistent with the demonstration rows", () => {
    const dashboard = createElement("c-employer-dashboard", {
      is: EmployerDashboard
    });
    document.body.appendChild(dashboard);

    const cards = [...dashboard.shadowRoot.querySelectorAll(".summary-card")];
    expect(
      cards.map((card) => [
        card.querySelector("dt").textContent,
        card.querySelector("dd").textContent
      ])
    ).toEqual([
      ["Active Employees", "3"],
      ["Open Requests", "2"],
      ["Completed Requests", "1"]
    ]);
  });
});
