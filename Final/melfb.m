function filterbank = melfb(num_filters, nfft, fs)

if num_filters < 1
    error('num_filters must be >= 1');
end

if nfft < 2 || nfft ~= floor(nfft)
    error('nfft must be an integer >= 2');
end

if fs <= 0
    error('Sampling frequency must be positive');
end

f_min = 0;
f_max = fs / 2;

mel_min = hz_to_mel(f_min);
mel_max = hz_to_mel(f_max);

mel_points = linspace(mel_min, mel_max, num_filters + 2);
hz_points = mel_to_hz(mel_points);

num_bins = floor(nfft / 2) + 1;

bin_points = floor(hz_points * nfft / fs) + 1;
bin_points = max(1, min(num_bins, bin_points));

if any(diff(bin_points) == 0)
    warning('Some mel filters have zero width. Increase nfft or reduce num_filters.');
end

filterbank = zeros(num_filters, num_bins);

for m = 1:num_filters
    left = bin_points(m);
    center = bin_points(m + 1);
    right = bin_points(m + 2);

    for k = left:center
        if center > left
            filterbank(m, k) = (k - left) / (center - left);
        end
    end

    for k = center:right
        if right > center
            filterbank(m, k) = (right - k) / (right - center);
        end
    end

    filter_sum = sum(filterbank(m, :));

    if filter_sum > 0
        filterbank(m, :) = filterbank(m, :) / filter_sum;
    end
end

end

function mel = hz_to_mel(hz)
mel = 2595 * log10(1 + hz / 700);
end

function hz = mel_to_hz(mel)
hz = 700 * (10.^(mel / 2595) - 1);
end