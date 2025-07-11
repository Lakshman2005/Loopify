import { useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { MusicPlayer } from "@/components/MusicPlayer";
import Home from "./Home";

const Index = () => {
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
    // TODO: Implement next track logic
    console.log("Next track");
  };

  const handlePrevious = () => {
    // TODO: Implement previous track logic
    console.log("Previous track");
  };

  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="flex">
        {/* Sidebar */}
        <Sidebar className="hidden lg:block" />
        
        {/* Main Content */}
        <div className="flex-1 lg:ml-0">
          <main className="p-6">
            <Home 
              onPlayTrack={handlePlayTrack}
              currentTrack={currentTrack}
              isPlaying={isPlaying}
            />
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
  );
};

export default Index;
