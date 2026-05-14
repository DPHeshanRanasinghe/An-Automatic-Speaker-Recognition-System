function log_mel = apply_log(mel_energies)

epsilon = eps;

log_mel = log(max(mel_energies, epsilon));

end