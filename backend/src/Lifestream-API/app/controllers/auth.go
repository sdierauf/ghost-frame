package controllers

import(
	"github.com/revel/revel"
	auth_system "Lifestream-API/private/auth"
	"net/url"
)

type Auth struct {
	*revel.Controller
	Token auth_system.ApiToken
}

func (c Auth) NewToken(owner string, level string) revel.Result {
	var headerStatus, missingHeaders = enforceHeaders([]string{"owner", "level"}, c.Params.Form)
	if !headerStatus {
		return c.RenderText("Missing values for headers %s", missingHeaders)
	}
	var status, token = c.Token.NewToken(owner, level)
	if status {
		return c.RenderText(token)
	} else {
		return c.RenderText("Oops! It looks like something went wrong.")
	}
}

func enforceHeaders(expectedHeaders []string, actualHeaders url.Values) (status bool, missingHeaders []string) {
	missingHeaders = make([]string, 0)
	for _, expectedHeader := range expectedHeaders {
		if actualHeaders.Get(expectedHeader) == "" {
			missingHeaders = append(missingHeaders, expectedHeader)
		}
	}
	status = (len(missingHeaders) == 0)
	return
}
