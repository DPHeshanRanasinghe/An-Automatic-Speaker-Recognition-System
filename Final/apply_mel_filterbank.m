function mel_energies = apply_mel_filterbank(power_spectrum, fs, nfft, num_filters)

[num_bins, ~] = size(power_spectrum);

expected_bins = floor(nfft / 2) + 1;

if num_bins ~= expected_bins
    error('Power spectrum has %d bins but expected %d bins for nfft=%d.', ...
          num_bins, expected_bins, nfft);
end

filterbank = melfb(num_filters, nfft, fs);

[fb_rows, fb_cols] = size(filterbank);

if fb_rows ~= num_filters
    error('Filterbank has %d rows but expected %d.', fb_rows, num_filters);
end

if fb_cols ~= num_bins
    error('Filterbank has %d columns but power_spectrum has %d bins.', ...
          fb_cols, num_bins);
end

mel_energies = filterbank * power_spectrum;

end