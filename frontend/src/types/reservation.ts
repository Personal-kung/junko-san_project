export interface Reservation {
  id?: number;
  customer_name: string;
  phone: string;
  service: string;
  reservation_date: string;
  status?: string;
  created_at?: string;
}