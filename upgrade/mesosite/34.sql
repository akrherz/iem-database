-- Store more things for auditing
ALTER TABLE autoplot_timing 
ADD COLUMN client_addr text,
ADD COLUMN http_agent text,
ADD COLUMN xff text;
