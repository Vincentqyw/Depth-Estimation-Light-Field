function loglike = lnormpdf(x, mu, sigma)

loglike =  (-0.5 * ((x - mu)./sigma).^2) - log(sqrt(2*pi) .* sigma);
