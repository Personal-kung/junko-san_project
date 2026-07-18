import {
    BrowserRouter,
    Navigate,
    Route,
    Routes,
} from "react-router-dom";

import Home from "../pages/Home";
import Reservation from "../pages/Reservation";
import Admin from "../pages/Admin";
import NotFound from "../pages/NotFound";

export default function AppRouter() {

    return (

        <BrowserRouter>

            <Routes>

                <Route
                    path="/"
                    element={<Home />}
                />

                <Route
                    path="/reservation"
                    element={<Reservation />}
                />

                <Route
                    path="/admin"
                    element={<Admin />}
                />

                <Route
                    path="*"
                    element={<NotFound />}
                />

            </Routes>

        </BrowserRouter>

    );

}