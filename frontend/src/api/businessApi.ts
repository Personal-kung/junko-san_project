import { API } from "../config/config";
import type { Business } from "../types/business";

export async function getBusiness(): Promise<Business> {

    const response = await fetch(API.business);

    if (!response.ok) {
        throw new Error("Unable to load business configuration");
    }

    return response.json();
}