import { useEffect, useState } from "react";
import ReservationTable from "../components/reservation/ReservationTable";
import { getReservations } from "../api/reservationApi";
import type { Reservation } from "../types/reservation";

export default function Admin() {
    const [reservations, setReservations] = useState<Reservation[]>([]);
    async function loadReservations() {
        const data = await getReservations();
        setReservations(data);
    }

    useEffect(() => {
        loadReservations();
    }, []);

    return (
        <main>
            <h1>Business Dashboard</h1>
            <ReservationTable
                reservations={reservations}
                onUpdated={loadReservations}
            />
        </main>
    );
}