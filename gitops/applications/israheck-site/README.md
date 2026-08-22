# Israheck site

This app serves [israheck.com](https://israheck.com) as a static site behind the
shared Envoy Gateway. Two small replicas run on separate workers when possible.
They accept traffic only from Envoy and have no outbound network access.
