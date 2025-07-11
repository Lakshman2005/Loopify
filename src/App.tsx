import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { MusicPlayer } from "@/components/MusicPlayer";
import Home from "./pages/Home";
import Search from "./pages/Search";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => {
  const [currentTrack, setCurrentTrack] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);

  const handlePlayTrack = (track: any) => {
    setCurrentTrack(track);
    setIsPlaying(true);
  };

  const handlePlayPause = () => {
    setIsPlaying(!isPlaying);
  };

  const handleNext = () => {
    console.log("Next track");
  };

  const handlePrevious = () => {
    console.log("Previous track");
  };

  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <div className="min-h-screen bg-background text-foreground">
            <div className="flex">
              {/* Sidebar */}
              <Sidebar className="hidden lg:block" />
              
              {/* Main Content */}
              <div className="flex-1 lg:ml-0">
                <main className="p-6">
                  <Routes>
                    <Route path="/" element={
                      <Home 
                        onPlayTrack={handlePlayTrack}
                        currentTrack={currentTrack}
                        isPlaying={isPlaying}
                      />
                    } />
                    <Route path="/search" element={
                      <Search 
                        onPlayTrack={handlePlayTrack}
                        currentTrack={currentTrack}
                        isPlaying={isPlaying}
                      />
                    } />
                    <Route path="*" element={<NotFound />} />
                  </Routes>
                </main>
              </div>
            </div>

            {/* Music Player */}
            <MusicPlayer
              currentTrack={currentTrack}
              isPlaying={isPlaying}
              onPlayPause={handlePlayPause}
              onNext={handleNext}
              onPrevious={handlePrevious}
            />
          </div>
        </BrowserRouter>
      </TooltipProvider>
    </QueryClientProvider>
  );
};

export default App;
