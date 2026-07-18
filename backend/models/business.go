package models

type Business struct {
	Name        string `json:"name"`
	Tagline     string `json:"tagline"`
	Description string `json:"description"`

	Phone   string `json:"phone"`
	Email   string `json:"email"`
	Address string `json:"address"`

	Instagram string `json:"instagram"`
	Facebook  string `json:"facebook"`
	Website   string `json:"website"`

	Logo      string `json:"logo"`
	HeroImage string `json:"hero_image"`

	PrimaryColor   string `json:"primary_color"`
	SecondaryColor string `json:"secondary_color"`
}
