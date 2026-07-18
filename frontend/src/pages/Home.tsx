import { Link } from "react-router-dom";

export default function Home() {

    return (

        <main>

            <h1>Junko-san Project</h1>

            <h2>Welcome</h2>

            <p>
                Online Reservation System
            </p>

            <p>

                <Link to="/reservation">

                    Make a Reservation

                </Link>

            </p>

            <p>

                <Link to="/admin">

                    Business Dashboard

                </Link>

            </p>

        </main>

    );

}