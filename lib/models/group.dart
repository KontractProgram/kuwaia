import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Group {
  final int id;
  final String name;
  final String description;
  final String icon;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

final List<Group> groups = [
  Group(
    id: 1,
    name: "Writing",
    description: "Craft compelling blogs, stories, and articles with smart AI assistance.",
    icon: "writingicon",
  ),
  Group(
    id: 2,
    name: "Image",
    description: "Create, edit, and enhance stunning visuals using powerful AI tools.",
    icon: "imageicon",
  ),
  Group(
    id: 3,
    name: "Video",
    description: "Effortlessly generate and edit professional-quality videos with AI.",
    icon: "videoicon",
  ),
  Group(
    id: 4,
    name: "Audio",
    description: "Record, edit, and master crystal-clear audio with AI-powered tools.",
    icon: "audioicon",
  ),
  Group(
    id: 5,
    name: "Music",
    description: "Compose, remix, and generate original music tracks using creative AI.",
    icon: "musicicon",
  ),
  Group(
    id: 6,
    name: "Graphic",
    description: "Design unique logos, posters, and graphics with intelligent AI support.",
    icon: "graphicicon",
  ),
  Group(
    id: 7,
    name: "Slide",
    description: "Build engaging presentations and dynamic slides in just minutes.",
    icon: "slideicon",
  ),
  Group(
    id: 8,
    name: "3D",
    description: "Model, animate, and render impressive 3D creations with AI tools.",
    icon: "3dicon",
  ),
  Group(
    id: 9,
    name: "Avatar",
    description: "Create personalized and expressive avatars, from realistic to cartoon.",
    icon: "avataricon",
  ),
  Group(
    id: 10,
    name: "Role Playing",
    description: "Supercharge marketing campaigns and copywriting with data-driven AI.",
    icon: "roleplaying",
  ),
  Group(
    id: 11,
    name: "Sales",
    description: "Drive sales, manage leads, and boost conversions with smart AI tools.",
    icon: "salesicon",
  ),
  Group(
    id: 12,
    name: "Productivity",
    description: "Boost your efficiency by organizing tasks, schedules, and workflows.",
    icon: "productivityicon",
  ),
  Group(
    id: 13,
    name: "Customer Support",
    description: "Deliver exceptional customer support with intelligent AI assistants.",
    icon: "customersupporticon",
  ),
  Group(
    id: 14,
    name: "HR",
    description: "Streamline recruiting, onboarding, and essential HR operations.",
    icon: "hricon",
  ),
  Group(
    id: 15,
    name: "Finance",
    description: "Manage budgets, accounting, and financial plans with smart AI insights.",
    icon: "financeicon",
  ),
  Group(
    id: 16,
    name: "Legal",
    description: "Simplify complex contracts, compliance, and critical legal workflows.",
    icon: "legalicon",
  ),
  Group(
    id: 17,
    name: "Security",
    description: "Enhance online safety with tools for monitoring and threat protection.",
    icon: "securityicon",
  ),
  Group(
    id: 18,
    name: "Crypto & Web3",
    description: "Navigate the world of blockchain, NFTs, and Web3 with AI tools.",
    icon: "cryptoweb3icon",
  ),
  Group(
    id: 19,
    name: "Coding",
    description: "Accelerate development with AI coding assistants and smart debuggers.",
    icon: "codingicon",
  ),
  Group(
    id: 20,
    name: "Data",
    description: "Analyze, visualize, and unlock insights from your data with AI power.",
    icon: "dataicon",
  ),
  Group(
    id: 21,
    name: "Studio",
    description: "Access all-in-one creative suites for every project, powered by AI.",
    icon: "studioicon",
  ),
  Group(
    id: 22,
    name: "Dev Platforms",
    description: "Build on development platforms and frameworks with integrated AI.",
    icon: "devplatformsicon",
  ),
  Group(
    id: 23,
    name: "Chat",
    description: "Engage users with intelligent chatbots and conversational AI agents.",
    icon: "chaticon",
  ),
  Group(
    id: 24,
    name: "Multimodal",
    description: "Experience AI that understands text, image, audio, and video inputs.",
    icon: "multimodalicon",
  ),
  Group(
    id: 25,
    name: "Agentic",
    description: "Deploy autonomous AI agents to automate tasks and achieve your goals.",
    icon: "agenticicon",
  ),
  Group(
    id: 26,
    name: "Search",
    description: "Find exactly what you need with smarter, AI-powered search tools.",
    icon: "searchicon",
  ),
  Group(
    id: 27,
    name: "Education",
    description: "Transform learning with personal AI tutors and interactive study aids.",
    icon: "educationicon",
  ),
  Group(
    id: 28,
    name: "Health",
    description: "Support your fitness, medical, and mental well-being with AI tools.",
    icon: "healthicon",
  ),
  Group(
    id: 29,
    name: "Travel",
    description: "Plan your next adventure, find flights, and explore with an AI guide.",
    icon: "travelicon",
  ),
  Group(
    id: 30,
    name: "Home & Life",
    description: "Improve daily routines and lifestyle with smart AI-powered tools.",
    icon: "homelifeicon",
  ),
];
// ✅ Group objects
// final List<Group> groups = [
//   Group(
//     id: 1,
//     name: "Writing",
//     description: "Tools to help you write blogs, stories, and articles with AI.",
//     icon: FontAwesomeIcons.penNib,
//   ),
//   Group(
//     id: 2,
//     name: "Image",
//     description: "AI tools for creating, editing, and enhancing images.",
//     icon: FontAwesomeIcons.image,
//   ),
//   Group(
//     id: 3,
//     name: "Video",
//     description: "Generate and edit videos with AI assistance.",
//     icon: FontAwesomeIcons.film,
//   ),
//   Group(
//     id: 4,
//     name: "Audio",
//     description: "Tools for recording, editing, and processing audio.",
//     icon: FontAwesomeIcons.headphones,
//   ),
//   Group(
//     id: 5,
//     name: "Music",
//     description: "Compose, remix, or generate music with AI.",
//     icon: FontAwesomeIcons.music,
//   ),
//   Group(
//     id: 6,
//     name: "Graphic",
//     description: "Design logos, posters, and graphics with AI support.",
//     icon: FontAwesomeIcons.palette,
//   ),
//   Group(
//     id: 7,
//     name: "Slide",
//     description: "Create engaging presentations and slides quickly.",
//     icon: FontAwesomeIcons.filePowerpoint,
//   ),
//   Group(
//     id: 8,
//     name: "3D",
//     description: "AI tools for 3D modeling, animation, and rendering.",
//     icon: FontAwesomeIcons.cube,
//   ),
//   Group(
//     id: 9,
//     name: "Avatar",
//     description: "Generate realistic or cartoon avatars.",
//     icon: FontAwesomeIcons.user,
//   ),
//   Group(
//     id: 10,
//     name: "Marketing",
//     description: "Boost campaigns, copywriting, and content marketing with AI.",
//     icon: FontAwesomeIcons.bullhorn,
//   ),
//   Group(
//     id: 11,
//     name: "Sales",
//     description: "AI-driven tools for leads, conversions, and CRM.",
//     icon: FontAwesomeIcons.shoppingCart,
//   ),
//   Group(
//     id: 12,
//     name: "Productivity",
//     description: "Organize tasks, schedules, and workflow efficiently.",
//     icon: FontAwesomeIcons.bolt,
//   ),
//   Group(
//     id: 13,
//     name: "Customer Support",
//     description: "AI chatbots and assistants to support customers.",
//     icon: FontAwesomeIcons.robot,
//   ),
//   Group(
//     id: 14,
//     name: "HR",
//     description: "Streamline recruiting, onboarding, and HR tasks.",
//     icon: FontAwesomeIcons.userTie,
//   ),
//   Group(
//     id: 15,
//     name: "Finance",
//     description: "AI for budgeting, accounting, and financial planning.",
//     icon: FontAwesomeIcons.dollarSign,
//   ),
//   Group(
//     id: 16,
//     name: "Legal",
//     description: "Simplify contracts, compliance, and legal tasks.",
//     icon: FontAwesomeIcons.scaleBalanced,
//   ),
//   Group(
//     id: 17,
//     name: "Security",
//     description: "Tools for online safety, monitoring, and protection.",
//     icon: FontAwesomeIcons.lock,
//   ),
//   Group(
//     id: 18,
//     name: "Crypto & Web3",
//     description: "Explore blockchain, NFTs, and crypto AI tools.",
//     icon: FontAwesomeIcons.bitcoin,
//   ),
//   Group(
//     id: 19,
//     name: "Coding",
//     description: "AI-powered coding assistants and debuggers.",
//     icon: FontAwesomeIcons.code,
//   ),
//   Group(
//     id: 20,
//     name: "Data",
//     description: "Analyze, visualize, and manage data with AI.",
//     icon: FontAwesomeIcons.chartLine,
//   ),
//   Group(
//     id: 21,
//     name: "Studio",
//     description: "All-in-one creative studios powered by AI.",
//     icon: FontAwesomeIcons.microphoneLines,
//   ),
//   Group(
//     id: 22,
//     name: "Dev Platforms",
//     description: "Development platforms and frameworks with AI support.",
//     icon: FontAwesomeIcons.server,
//   ),
//   Group(
//     id: 23,
//     name: "Chat",
//     description: "AI chatbots and conversational assistants.",
//     icon: FontAwesomeIcons.commentDots,
//   ),
//   Group(
//     id: 24,
//     name: "Multimodal",
//     description: "AI that combines text, image, audio, and video inputs.",
//     icon: FontAwesomeIcons.layerGroup,
//   ),
//   Group(
//     id: 25,
//     name: "Agentic",
//     description: "Autonomous AI agents that perform tasks for you.",
//     icon: FontAwesomeIcons.robot,
//   ),
//   Group(
//     id: 26,
//     name: "Search",
//     description: "AI-powered search and discovery tools.",
//     icon: FontAwesomeIcons.magnifyingGlass,
//   ),
//   Group(
//     id: 27,
//     name: "Education",
//     description: "AI tutors, learning apps, and study assistants.",
//     icon: FontAwesomeIcons.graduationCap,
//   ),
//   Group(
//     id: 28,
//     name: "Health",
//     description: "AI for fitness, medicine, and mental health.",
//     icon: FontAwesomeIcons.heartbeat,
//   ),
//   Group(
//     id: 29,
//     name: "Travel",
//     description: "Plan trips, find flights, and explore with AI.",
//     icon: FontAwesomeIcons.plane,
//   ),
//   Group(
//     id: 30,
//     name: "Home & Life",
//     description: "Smart living tools for daily life and lifestyle.",
//     icon: FontAwesomeIcons.house,
//   ),
// ];
