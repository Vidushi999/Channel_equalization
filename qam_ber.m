function [berEst] = qpsk_ber()

M = 64;                 % Modulation order
k = log2(M);            % Bits per symbol
EbNoVec = (5:15)';      % Eb/No values (dB)
global numSymPerFrame;
numSymPerFrame = 100;   % Number of QAM symbols per frame
berEstR = zeros(size(EbNoVec));
berEstC = zeros(size(EbNoVec));

for n = 1:length(EbNoVec)
    % Convert Eb/No to SNR
    snrdB = EbNoVec(n) + 10*log10(k);
    % Reset the error and bit counters
    numErrs = 0;
    numBits = 0;
    
    %Training%%%%%%%%%%%%%%%%%%%%%%%%%%
    signal = randn(1,500);%signal power is now 1
    signal_power = 1;
    noise_power = signal_power/db2mag(snrdB);
    order = 8; step_size = 0.08;%with 8 it is giving overflow error
    noise=sqrt(noise_power)*randn(1,500);
    desired_output=signal;
    channel_fc = fir1(3,0.5);%define fir filter and return coeff. in channel
    channel_op = filter(channel_fc,1,desired_output);%perform conv opn
    adapt_input = channel_op + noise;
    [filtered_signal, y,fc] = lmsAlgoOrig(channel_op, desired_output, step_size,order);
    mse(n)=sqrt(mean(y.*y));%error should be less than 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

    while numBits < 1e4 %1e7%numErrs < 200 && numBits < 1e7 %testing over 10^6 bits
        % Generate binary data and convert to symbols
        dataIn = randi([0 1],numSymPerFrame,k);
        dataSym = bi2de(dataIn);

        % QAM modulate using 'Gray' symbol mapping
        txSig = qammod(dataSym,M,0,'gray');%its average power is mp 0.5
        txSigR = real(txSig);
        txSigC = imag(txSig);
       
        txSig1R=filter(channel_fc,1,txSigR);
        rxSigR = txSig1R + (0.5*sqrt(0.5/db2mag(snrdB)))*randn(numSymPerFrame,1);%awgn(txSig1,snrdB,'measured');
        rxSig1R=filter(fc,1,rxSigR);
        
        txSig1C=filter(channel_fc,1,txSigC);
        rxSigC = txSig1C + (0.5*sqrt(0.5/db2mag(snrdB)))*randn(numSymPerFrame,1);%awgn(txSig1,snrdB,'measured');
        rxSig1C=filter(fc,1,rxSigC);
        
        rxSig1 = rxSig1R + i*rxSigC;
        % Demodulate the noisy signal
        rxSym = qamdemod(rxSig1,M,0,'gray');
        % Convert received symbols to bits
        dataOut = de2bi(rxSym,k);%dataOut is always 1

        % Calculate the number of bit errors
        nErrors = biterr(dataIn,dataOut);

        % Increment the error and bit counters
        numErrs = numErrs + nErrors;
        numBits = numBits + numSymPerFrame*k;
        
      
    end
      berEst(n) = numErrs/numBits;
end
end
%berTheory = berawgn(EbNoVec,'qam',M);

% semilogy(EbNoVec,berEst,'*')
% % hold on
% % semilogy(EbNoVec,berTheory)
% grid
% legend('Estimated BER')%,'Theoretical BER')
% xlabel('Eb/No (dB)')
% ylabel('Bit Error Rate')