import { application } from "./application";

const controllers = import.meta.glob("./**/*_controller.js", { eager: true });

for (const path in controllers) {
  const controller = controllers[path].default;
  const name = path
    .split("/")
    .pop()
    .replace(/_controller\.js$/, "")
    .replace(/_/g, "-");
  application.register(name, controller);
}
