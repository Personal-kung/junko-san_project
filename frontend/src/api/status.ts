import { API } from "../config/config";

export interface StatusResponse {
    status: string;
    system: string;
}

export async function getStatus(): Promise<StatusResponse> {

    const response = await fetch(API.status);

    if (!response.ok) {
        throw new Error("Unable to connect to backend");
    }

    return response.json();
}