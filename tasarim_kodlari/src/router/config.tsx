
import type { RouteObject } from "react-router-dom";
import NotFound from "../pages/NotFound";
import Home from "../pages/home/page";
import Notifications from "../pages/notifications/page";

const routes: RouteObject[] = [
  {
    path: "/",
    element: <Home />,
  },
  {
    path: "/notifications",
    element: <Notifications />,
  },
  {
    path: "*",
    element: <NotFound />,
  },
];

export default routes;
