import { LightningElement } from "lwc";

const DEMO_WORKFORCE = [
  {
    key: "demo-worker-1",
    name: "Mira Cove",
    role: "Guest Services Coordinator",
    status: "Active",
    statusClass: "status status--positive"
  },
  {
    key: "demo-worker-2",
    name: "Theo Vale",
    role: "Facilities Technician",
    status: "Active",
    statusClass: "status status--positive"
  },
  {
    key: "demo-worker-3",
    name: "Nia Lark",
    role: "Operations Associate",
    status: "Active",
    statusClass: "status status--positive"
  },
  {
    key: "demo-worker-4",
    name: "Ari Fern",
    role: "Reservations Specialist",
    status: "Leave",
    statusClass: "status status--neutral"
  }
];

const DEMO_REQUESTS = [
  {
    key: "demo-request-1",
    title: "Job title change",
    employee: "Mira Cove",
    status: "In Progress",
    statusClass: "status status--progress"
  },
  {
    key: "demo-request-2",
    title: "Department change",
    employee: "Nia Lark",
    status: "In Progress",
    statusClass: "status status--progress"
  },
  {
    key: "demo-request-3",
    title: "Employment type change",
    employee: "Theo Vale",
    status: "Completed",
    statusClass: "status status--positive"
  }
];

export default class EmployerDashboard extends LightningElement {
  workforce = DEMO_WORKFORCE;
  requests = DEMO_REQUESTS;

  get summary() {
    return [
      {
        key: "active",
        label: "Active Employees",
        count: this.workforce.filter(({ status }) => status === "Active").length
      },
      {
        key: "open",
        label: "Open Requests",
        count: this.requests.filter(({ status }) => status === "In Progress")
          .length
      },
      {
        key: "completed",
        label: "Completed Requests",
        count: this.requests.filter(({ status }) => status === "Completed")
          .length
      }
    ];
  }
}
