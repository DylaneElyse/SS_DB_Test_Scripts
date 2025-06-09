FROM postgres

# Set the environment variable for the PostgreSQL user
ENV POSTGRES_USER=postgres

# Set the environment variable for the PostgreSQL password
ENV POSTGRES_PASSWORD=321drowssap

# Set the environment variable for the PostgreSQL database
ENV POSTGRES_DB=postgres

# Copy the SQL script to the Docker image
COPY init.sql /docker-entrypoint-initdb.d/

# Expose the PostgreSQL port
EXPOSE 5432

# Set the default command to run PostgreSQL
CMD ["postgres"]

# Note: The init.sql script should be placed in the same directory as this Dockerfile
# and should contain the SQL commands to initialize the database.
