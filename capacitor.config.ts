import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.lovable.c5f917630e984f3895e4dad7e7ccde72',
  appName: 'A Lovable project',
  webDir: 'dist',
  server: {
    url: 'https://c5f91763-0e98-4f38-95e4-dad7e7ccde72.lovableproject.com?forceHideBadge=true',
    cleartext: true
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: '#1a1a1a',
      androidSplashResourceName: 'splash',
      androidScaleType: 'CENTER_CROP'
    }
  }
};

export default config;