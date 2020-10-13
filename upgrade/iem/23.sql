-- See akrherz/iem#260, track insertion time.
ALTER TABLE current ADD updated timestamptz DEFAULT now();
ALTER TABLE current_log ADD updated timestamptz DEFAULT now();
