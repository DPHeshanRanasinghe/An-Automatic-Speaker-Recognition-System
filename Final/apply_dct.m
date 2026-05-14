function mfcc_coeffs = apply_dct(log_mel, num_coeffs)

[num_filters, ~] = size(log_mel);

if num_coeffs < 1
    error('num_coeffs must be >= 1');
end

if num_coeffs > num_filters
    error('num_coeffs (%d) cannot be > num_filters (%d)', ...
          num_coeffs, num_filters);
end

dct_result = dct(log_mel);
mfcc_coeffs = dct_result(1:num_coeffs, :);

end