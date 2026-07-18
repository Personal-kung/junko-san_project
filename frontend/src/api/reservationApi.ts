import { API } from "../config/config";

import type { Reservation } from "../types/reservation";
import type { Service } from "../types/service";

export async function getReservations(): Promise<Reservation[]> {

    const response = await fetch(API.reservations);

    if (!response.ok) {
        throw new Error("Failed to load reservations");
    }

    return response.json();
}

export async function createReservation(
    reservation: Reservation
): Promise<Reservation> {

    const response = await fetch(API.reservations, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(reservation),
    });

    if (!response.ok) {
        throw new Error("Failed to create reservation");
    }

    return response.json();
}

export async function getServices(): Promise<Service[]> {

    const response = await fetch(API.services);

    if (!response.ok) {
        throw new Error("Failed to load services");
    }

    return response.json();
}

export async function updateReservationStatus(
    id: number,
    status: "pending" | "approved" | "rejected"
) {

    const response = await fetch(
        `${API.reservations}?id=${id}`,
        {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                status,
            }),
        }
    );

    if (!response.ok) {
        throw new Error("Failed to update reservation");
    }

    return response.json();
}