-- Store more things for auditing
ALTER TABLE autoplot_timing 
ADD COLUMN client_addr text,
ADD COLUMN user_agent text,
ADD COLUMN xff text;
