 clc;
 clear;
 close all;

[ori_y , fs1] = audioread('PS8Raw.wav'); 
 disp(fs1) 
 N = length(ori_y); 
 
 % Original time domain 
 
 figure(1); 
 t = 1/fs1:1/fs1:N/fs1; 
 plot(t,ori_y);  
 
 
 % Original freq domain 
 
 figure(2); 
 f = linspace(-fs1/2,fs1/2,N); 
 ori_Y = fft(ori_y,N); 
 plot( f, fftshift(abs(ori_Y))); 
 
 
 [scr_y,fs] = audioread('PS8Scrambled.wav'); 
 N = length(scr_y); 
 
 
 % Scrambled time domain 
 
 figure(3); 
 t = 1/fs:1/fs:N/fs; 
 plot(t,scr_y); 
 
 
 % Scrambled freq domain 
 
 figure(4); 
 f = linspace(-fs/2,fs/2,N); 
 scr_Y = fft(scr_y,N); 
 plot(f,fftshift(abs(scr_Y)));  
 [pk,MaxFreq] = findpeaks(fftshift(abs(scr_Y)),'NPeaks',1,'SortStr','descend'); 
 hold on 
 plot(f(MaxFreq),pk,'or') 
 hold off 
 Freq = f(MaxFreq) ;
 

 % Chebyshev Band-stop filter 
 h  = fdesign.bandstop('N,Fp1,Fp2,Ap', 2, 3300, 3700, 1, fs); 
 bandstop = design(h, 'cheby1'); 
 
 
 % Chebyshev low-pass filter 
 h  = fdesign.lowpass(3000, 3500, 1, 40, fs);  %constructs a lowpass filter specification object D, applying default values for the default specification string 'Fp,Fst,Ap,Ast'.
 Hd = design(h, 'cheby1', 'MatchExactly', 'passband'); 
 
 
 % Chebyshev low-pass 5000 
 h  = fdesign.lowpass('N,Fp,Ap', 4, 5000, 1, fs); 
 lowpass = design(h, 'cheby1'); 
 
 % Remove 3500Hz tone 
 scr_y_lp = filter(bandstop, scr_y); 
 
  % Scrambled * 3500Hz 
 sine = sin(2*pi*3500*t).'; 
 scr_y_sin = scr_y_lp .* sine; 
 
 
 % Remove upper frequencies 
 scr_y_sin_lp = filter(lowpass, scr_y_sin); 
 
 
 % Unscrambled freq domain 
 figure(5); 
 f = linspace(-fs/2,fs/2,N); 
 unscr_Y = fft(scr_y_sin_lp,N); 
 plot(f,fftshift(abs(unscr_Y))); 
 
 %unscrambled time domain
  figure(6);
  t = 1/fs:1/fs:N/fs; 
  plot(t,scr_y_sin_lp);  
 
 
% Play original sound 
sound(ori_y, fs1);

% Play unscrambled sound
sound(scr_y_sin_lp, fs);


filename1 = 'original.wav';
audiowrite(filename1,ori_y,fs1);
fs1
clear ori_y fs1

filename2 = 'descrambled.wav';
audiowrite(filename2,scr_y_sin_lp,fs);
fs
clear ori_y fs

