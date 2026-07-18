import { updateReservationStatus } from "../../api/reservationApi";
import type { Reservation } from "../../types/reservation";

interface Props {
    reservations: Reservation[];
    onUpdated: () => void;
}

export default function ReservationList({
    reservations,
    onUpdated,
}: Props) {
    async function approve(id: number) {
        await updateReservationStatus(id, "approved");
        onUpdated();
    }

    async function reject(id: number) {
        await updateReservationStatus(id, "rejected");

        onUpdated();
    }

    return (
        <div>
            <h2>Reservations</h2>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Phone</th>
                        <th>Service</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {reservations.map((reservation) => (
                        <tr key={reservation.id}>
                            <td>{reservation.id}</td>
                            <td>{reservation.customer_name}</td>
                            <td>{reservation.phone}</td>
                            <td>{reservation.service}</td>
                            <td>{reservation.reservation_date}</td>
                            <td>{reservation.status}</td>
                            <td>
                                <button
                                    onClick={() =>
                                        approve(reservation.id!)
                                    }
                                >
                                    Approve
                                </button>
                                <button
                                    onClick={() =>
                                        reject(reservation.id!)
                                    }
                                >
                                    Reject
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}