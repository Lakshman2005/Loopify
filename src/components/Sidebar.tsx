import { Home, Search, Library, Heart, Plus, Music } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { NavLink } from "react-router-dom";

interface SidebarProps {
  className?: string;
}

export function Sidebar({ className = "" }: SidebarProps) {
  const mainNavItems = [
    { icon: Home, label: "Home", href: "/" },
    { icon: Search, label: "Search", href: "/search" },
    { icon: Library, label: "Your Library", href: "/library" },
  ];

  const libraryItems = [
    { icon: Heart, label: "Liked Songs", href: "/liked" },
    { label: "My Playlist #1", href: "/playlist/1" },
    { label: "Chill Vibes", href: "/playlist/2" },
    { label: "Workout Mix", href: "/playlist/3" },
  ];

  return (
    <div className={`w-64 h-screen bg-background border-r border-border ${className}`}>
      <div className="p-6">
        {/* Logo */}
        <div className="flex items-center gap-2 mb-8">
          <div className="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center">
            <Music className="h-5 w-5 text-white" />
          </div>
          <span className="text-xl font-bold text-foreground">Loopify</span>
        </div>

        {/* Main Navigation */}
        <nav className="space-y-2 mb-8">
          {mainNavItems.map((item) => (
            <NavLink
              key={item.href}
              to={item.href}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2 rounded-lg transition-colors ${
                  isActive
                    ? "bg-accent text-music-primary"
                    : "text-muted-foreground hover:text-foreground hover:bg-accent/50"
                }`
              }
            >
              <item.icon className="h-5 w-5" />
              <span className="font-medium">{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <Separator className="mb-6" />

        {/* Library Section */}
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider">
              Your Library
            </h3>
            <Button variant="ghost" size="sm" className="h-6 w-6 p-0">
              <Plus className="h-4 w-4" />
            </Button>
          </div>

          <nav className="space-y-1">
            {libraryItems.map((item, index) => (
              <NavLink
                key={item.href}
                to={item.href}
                className={({ isActive }) =>
                  `flex items-center gap-3 px-3 py-2 rounded-lg transition-colors text-sm ${
                    isActive
                      ? "bg-accent text-music-primary"
                      : "text-muted-foreground hover:text-foreground hover:bg-accent/50"
                  }`
                }
              >
                {item.icon && <item.icon className="h-4 w-4" />}
                {!item.icon && index > 0 && (
                  <div className="w-4 h-4 bg-gradient-secondary rounded-sm flex items-center justify-center">
                    <Music className="h-2.5 w-2.5 text-white" />
                  </div>
                )}
                <span className="truncate">{item.label}</span>
              </NavLink>
            ))}
          </nav>
        </div>

        {/* Upgrade Card */}
        <Card className="mt-8 p-4 bg-gradient-primary text-white">
          <div className="space-y-2">
            <h4 className="font-semibold">Upgrade to Premium</h4>
            <p className="text-sm opacity-90">
              Enjoy unlimited music with high quality audio
            </p>
            <Button variant="secondary" size="sm" className="w-full mt-3">
              Get Premium
            </Button>
          </div>
        </Card>
      </div>
    </div>
  );
}