import os

# Set to localhost or a socket path.
PG_HOST = os.getenv('PGHOST', '/var/run/postgresql')

# Might want to use a proper user.
PG_USER = os.getenv('PGUSER', 'postgres')

# These are pretty much standard.
PG_PORT = os.getenv('PGPORT', '5432')
PG_DATABASE = os.getenv('PGDATABASE', 'geocoder')
