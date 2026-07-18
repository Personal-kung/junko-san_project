import { useState } from "react";

import ReservationForm from "../components/reservation/ReservationForm";

export default function Reservation() {
    const [, forceRefresh] = useState(0);
    return (
        <main>
            <h1>Reservation</h1>
            <ReservationForm
                onCreated={() => forceRefresh(value => value + 1)}
            />
        </main>
    );
}