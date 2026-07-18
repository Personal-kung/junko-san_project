import { useEffect, useState } from "react";

import {
    createReservation,
    getServices,
} from "../../api/reservationApi";

import type { Service } from "../../types/service";

interface Props {
    onCreated: () => void;
}

export default function ReservationForm({ onCreated }: Props) {

    const [customer, setCustomer] = useState("");
    const [phone, setPhone] = useState("");
    const [service, setService] = useState("");
    const [date, setDate] = useState("");

    const [services, setServices] = useState<Service[]>([]);

    useEffect(() => {

        async function loadServices() {

            try {

                const data = await getServices();

                setServices(data);

                if (data.length > 0) {
                    setService(data[0].name);
                }

            } catch (error) {

                console.error(error);

            }

        }

        loadServices();

    }, []);

    async function submit(e: React.FormEvent) {

        e.preventDefault();

        await createReservation({

            customer_name: customer,
            phone,
            service,
            reservation_date: date,

        });

        setCustomer("");
        setPhone("");
        setDate("");

        if (services.length > 0) {
            setService(services[0].name);
        }

        onCreated();
    }

    return (

        <form onSubmit={submit}>

            <h2>New Reservation</h2>

            <input
                placeholder="Customer name"
                value={customer}
                onChange={e => setCustomer(e.target.value)}
            />

            <input
                placeholder="Phone"
                value={phone}
                onChange={e => setPhone(e.target.value)}
            />

            <select
                value={service}
                onChange={e => setService(e.target.value)}
            >

                {
                    services.map(service => (

                        <option
                            key={service.id}
                            value={service.name}
                        >
                            {service.name}
                        </option>

                    ))
                }

            </select>

            <input
                type="datetime-local"
                value={date}
                onChange={e => setDate(e.target.value)}
            />

            <button type="submit">
                Create Reservation
            </button>

        </form>

    );

}