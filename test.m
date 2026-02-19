mfcc   = mfcc_dct(logMel, 13);     % 13 coefficients
delta  = mfcc_delta(mfcc, 2);
delta2 = mfcc_delta(delta, 2);     % Don't call mfcc_delta_delta
features = [mfcc delta delta2];    % 39-dimensional features